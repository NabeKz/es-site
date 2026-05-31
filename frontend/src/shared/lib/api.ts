export type OkResult<T> = { ok: true; data: T }
export type ErrResult = { ok: false; status: number }
export type ApiResult<T> = OkResult<T> | ErrResult

// XHR の慣習に倣い、HTTP に到達できないネットワークエラーを 0 で表す
export const NETWORK_ERROR = 0

export const toResult = async <T>(
  promise: Promise<{ data: T | void; status: number }>,
): Promise<ApiResult<T>> => {
  try {
    const res = await promise
    return res.status >= 200 && res.status < 300
      ? { ok: true, data: res.data as T }
      : { ok: false, status: res.status }
  } catch {
    return { ok: false, status: NETWORK_ERROR }
  }
}

export const isOk = <T>(result: ApiResult<T>): result is OkResult<T> => result.ok
