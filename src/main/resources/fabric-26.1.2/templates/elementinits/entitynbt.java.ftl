package ${package}.procedures;

import net.fabricmc.fabric.api.attachment.v1.AttachmentRegistry;
import net.fabricmc.fabric.api.attachment.v1.AttachmentType;
import net.minecraft.nbt.CompoundTag;
import net.minecraft.nbt.NbtOps;
import net.minecraft.resources.Identifier;
import net.minecraft.world.entity.Entity;
import net.minecraft.world.item.ItemStack;

/**
 * Fabric-compatible replacement for NeoForge's Entity#getPersistentData().
 * The compound tag is stored as a persistent Fabric attachment on the entity.
 */
public final class ${JavaModName}EntityNbt {
	public static final AttachmentType<CompoundTag> NBT = AttachmentRegistry.create(
			Identifier.fromNamespaceAndPath(${JavaModName}.MODID, "entity_nbt"),
			(builder) -> builder.persistent(CompoundTag.CODEC).initializer(CompoundTag::new));

	private ${JavaModName}EntityNbt() {
	}

	public static CompoundTag get(Entity entity) {
		return entity.getAttachedOrCreate(NBT);
	}

	public static ItemStack getItemStack(Entity entity, String key) {
		CompoundTag tag = get(entity);
		if (!tag.contains(key))
			return ItemStack.EMPTY;
		return ItemStack.OPTIONAL_CODEC.parse(NbtOps.INSTANCE, tag.get(key)).result().orElse(ItemStack.EMPTY);
	}

	public static void setItemStack(Entity entity, String key, ItemStack stack) {
		CompoundTag tag = get(entity);
		ItemStack.OPTIONAL_CODEC.encodeStart(NbtOps.INSTANCE, stack).result().ifPresent(value -> tag.put(key, value));
	}
}
