public static boolean canInsertInBlockInventory(LevelAccessor world, BlockPos pos, int slotId, int amount, ItemStack itemstack) {
	BlockEntity blockEntity = world.getBlockEntity(pos);
	if (blockEntity instanceof Container container && slotId >= 0 && slotId < container.getContainerSize()) {
		if (!container.canPlaceItem(slotId, itemstack))
			return false;
		ItemStack existing = container.getItem(slotId);
		int limit = container.getMaxStackSize(itemstack);
		if (existing.isEmpty())
			return amount <= limit;
		return ItemStack.isSameItemSameComponents(existing, itemstack) && existing.getCount() + amount <= limit;
	}
	return false;
}
