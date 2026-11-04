<#include "mcitems.ftl">
if (${input$entity} != null) ${JavaModName}EntityNbt.setItemStack(${input$entity}, ${input$tagName}, ${mappedMCItemToItemStackCode(input$tagValue, 1)});
