import lustre/attribute.{type Attribute, style}
import lustre/element.{type Element}
import lustre/element/html

pub fn vstack(
  attrs: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  html.div(
    [style("display", "flex"), style("flex-direction", "column"), ..attrs],
    children,
  )
}

pub fn hstack(
  attrs: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  html.div(
    [style("display", "flex"), style("flex-direction", "row"), ..attrs],
    children,
  )
}

pub fn grid(
  attrs: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  html.div([style("display", "grid"), ..attrs], children)
}
