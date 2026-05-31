import { readFile, readdir } from "fs/promises"
import { join, basename } from "path"
import { existsSync } from "fs"

const TEST_DIR = "test"
const RESULTS_DIR = "test-results"

type Status = "passed" | "failed" | "skipped"

type GleamTest = {
  functionName: string
  japaneseName: string | null
}

type GleamFile = {
  moduleName: string
  userStory: string
  tests: GleamTest[]
}

const testLabelComment = /^\/\/\s*test:\s*(.+)/
const userStoryComment = /^\/\/\s*User Story:\s*(.+)/
const testFunctionDecl = /^pub fn (\w+_test)\s*\(/
const testcaseXml = /<testcase[^>]+name="[^"]*\s+(\w+)"[^>]*>([\s\S]*?)<\/testcase>|<testcase[^>]+name="[^"]*\s+(\w+)"[^>]*\/>/g

const extractTestLabel = (line: string): string | null =>
  line.match(testLabelComment)?.[1].trim() ?? null

const parseGleamFile = async (filePath: string): Promise<GleamFile> => {
  const lines = (await readFile(filePath, "utf-8")).split("\n")

  const userStory =
    lines.map(line => line.match(userStoryComment)?.[1]).find(Boolean) ?? ""

  const tests = lines.flatMap((line, i) => {
    const m = line.match(testFunctionDecl)
    const japaneseName = extractTestLabel(lines[i - 1] ?? "")
    return m ? [{ functionName: m[1], japaneseName }] : []
  })

  return { moduleName: basename(filePath, ".gleam"), userStory, tests }
}

const parseXml = async (filePath: string): Promise<Map<string, Status>> => {
  const content = await readFile(filePath, "utf-8")
  return new Map(
    [...content.matchAll(testcaseXml)].map(m => {
      const name = m[1] ?? m[3]
      const body = m[2] ?? ""
      const status: Status = body.includes("<failure") ? "failed"
        : body.includes("<skipped") ? "skipped"
        : "passed"
      return [name, status] as [string, Status]
    })
  )
}

const scanTestFiles = async (dir: string): Promise<string[]> => {
  const entries = await readdir(dir, { withFileTypes: true })
  const paths = await Promise.all(
    entries.map(e => {
      const p = join(dir, e.name)
      if (e.isDirectory()) return scanTestFiles(p)
      return e.name.endsWith("_test.gleam") ? [p] : []
    })
  )
  return paths.flat()
}

const loadXmlMap = async (): Promise<Map<string, Map<string, Status>>> => {
  if (!existsSync(RESULTS_DIR)) return new Map()
  const xmlFiles = (await readdir(RESULTS_DIR)).filter(f => f.endsWith(".xml"))
  const entries = await Promise.all(
    xmlFiles.map(async (f: string) => {
      const raw = basename(f, ".xml").replace("TEST-", "")
      const parts = raw.split("@")
      const moduleName = raw.includes("@") ? parts[parts.length - 1] : raw
      return [moduleName, await parseXml(join(RESULTS_DIR, f))] as const
    })
  )
  return new Map(entries)
}

const testIcon = (status: Status | undefined): string =>
  status === "passed" ? "✅" : status === "failed" ? "❌" : "⚠️"

const formatFileSection = (file: GleamFile, results: Map<string, Status>): string[] => {
  const rows = file.tests.map(
    test => `| ${test.japaneseName ?? test.functionName} | ${testIcon(results.get(test.functionName))} |`
  )
  return [`### ${file.userStory || file.moduleName}`, "", "| テスト | 結果 |", "|--------|------|", ...rows, ""]
}

const main = async () => {
  const gleamFiles = await Promise.all(
    (await scanTestFiles(TEST_DIR)).map(parseGleamFile)
  ).then(files => files.sort((a, b) => a.moduleName.localeCompare(b.moduleName)))

  const xmlMap = await loadXmlMap()

  const allStatuses = [...xmlMap.values()].flatMap(m => [...m.values()])
  const passed = allStatuses.filter(s => s === "passed").length
  const failed = allStatuses.filter(s => s === "failed").length

  const header = `## ${failed === 0 ? "✅" : "❌"} テスト結果: ${passed} passed${failed > 0 ? `, ${failed} failed` : ""}`
  const body = gleamFiles
    .filter(file => file.tests.length > 0)
    .flatMap(file => formatFileSection(file, xmlMap.get(file.moduleName) ?? new Map()))
    .join("\n")

  const out = `${header}\n\n${body}`

  const summaryFile = process.env.GITHUB_STEP_SUMMARY
  if (summaryFile) await Bun.write(summaryFile, out)
  else process.stdout.write(out)
}

main().catch(console.error)
