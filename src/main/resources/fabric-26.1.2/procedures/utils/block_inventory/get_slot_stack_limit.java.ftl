private static int getBlockInventorySlotStackLimit(LevelAccessor world, BlockPos pos, int slotId) {
	BlockEntity blockEntity = world.getBlockEntity(pos);
	if (blockEntity instanceof Container container && slotId >= 0 && slotId < container.getContainerSize())
		return container.getMaxStackSize(container.getItem(slotId));
	return 0;
}
