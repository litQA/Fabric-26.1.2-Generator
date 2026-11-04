<#include "mcitems.ftl">
/*@ItemStack*/(${input$entity} == null ? ItemStack.EMPTY : ${JavaModName}EntityNbt.getItemStack(${input$entity}, ${input$tagName}))
