private static ItemStack extractFromBlockInventory(LevelAccessor world, BlockPos pos, int slotId, int amount, boolean simulate) {
	BlockEntity blockEntity = world.getBlockEntity(pos);
	if (blockEntity instanceof Container container && slotId >= 0 && slotId < container.getContainerSize()) {
		ItemStack extractedStack = container.getItem(slotId);
		if (extractedStack.isEmpty() || amount < 0)
			return ItemStack.EMPTY;
		ItemStack result = extractedStack.copy();
		result.setCount(Math.min(amount, extractedStack.getCount()));
		if (!simulate) {
			ItemStack remaining = extractedStack.copy();
			remaining.shrink(result.getCount());
			container.setItem(slotId, remaining.isEmpty() ? ItemStack.EMPTY : remaining);
		}
		return result;
	}
	return ItemStack.EMPTY;
}
