private static int insertInBlockInventory(LevelAccessor world, BlockPos pos, int slotId, int amount, ItemStack itemstack, boolean simulate) {
	BlockEntity blockEntity = world.getBlockEntity(pos);
	if (blockEntity instanceof Container container && slotId >= 0 && slotId < container.getContainerSize() && container.canPlaceItem(slotId, itemstack)) {
		ItemStack existing = container.getItem(slotId);
		int limit = container.getMaxStackSize(itemstack);
		if (existing.isEmpty()) {
			int inserted = Math.min(amount, limit);
			if (!simulate && inserted > 0) {
				ItemStack result = itemstack.copy();
				result.setCount(inserted);
				container.setItem(slotId, result);
			}
			return amount - inserted;
		}
		if (ItemStack.isSameItemSameComponents(existing, itemstack)) {
			int inserted = Math.min(amount, Math.max(0, limit - existing.getCount()));
			if (!simulate && inserted > 0) {
				ItemStack result = existing.copy();
				result.grow(inserted);
				container.setItem(slotId, result);
			}
			return amount - inserted;
		}
	}
	return amount;
}
