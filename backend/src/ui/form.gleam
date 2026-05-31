import lustre/attribute.{type Attribute, style}
import lustre/element.{type Element}
import lustre/element/html

/// label の中に input を入れて for/id なしで関連付け
pub fn field(
  label_text: String,
  input_attrs: List(Attribute(msg)),
) -> Element(msg) {
  html.label([], [html.text(label_text), html.input(input_attrs)])
}

pub fn button(
  attrs: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  html.button([style("cursor", "pointer"), ..attrs], children)
}
