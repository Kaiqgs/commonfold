components {
  id: "sprite_child"
  component: "/common/gameobjects/spritezes/spritezes_child.script"
  properties {
    id: "image"
    value: "/assets/bg.tilesource"
    type: PROPERTY_TYPE_HASH
  }
  properties {
    id: "material"
    value: "/builtins/materials/sprite.material"
    type: PROPERTY_TYPE_HASH
  }
}
embedded_components {
  id: "sprite"
  type: "sprite"
  data: "default_animation: \"udyr_act_good\"\n"
  "material: \"/builtins/materials/sprite.material\"\n"
  "textures {\n"
  "  sampler: \"texture_sampler\"\n"
  "  texture: \"/assets/dog.tilesource\"\n"
  "}\n"
  ""
}
