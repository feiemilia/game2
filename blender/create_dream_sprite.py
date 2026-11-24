"""Build the original Little Dream Sprite model and save a Blender project + GLB."""
import bpy
import math
import os
from mathutils import Vector

bpy.ops.object.select_all(action="SELECT")
bpy.ops.object.delete(use_global=False)

def material(name, color, metallic=0.0, roughness=0.45, emission=0.0):
    m = bpy.data.materials.new(name)
    m.diffuse_color = (*color, 1.0)
    m.use_nodes = True
    bsdf = m.node_tree.nodes.get("Principled BSDF")
    bsdf.inputs["Base Color"].default_value = (*color, 1.0)
    bsdf.inputs["Metallic"].default_value = metallic
    bsdf.inputs["Roughness"].default_value = roughness
    if emission:
        bsdf.inputs["Emission Color"].default_value = (*color, 1.0)
        bsdf.inputs["Emission Strength"].default_value = emission
    return m

hood = material("Hood | midnight plum", (0.10, 0.105, 0.20), roughness=0.32)
cape = material("Cape | violet velvet", (0.22, 0.18, 0.36), roughness=0.52)
face = material("Face | warm dusk", (0.18, 0.17, 0.27), roughness=0.38)
eye = material("Eyes | moon cream", (1.0, 0.82, 0.48), emission=1.4)
gold = material("Lantern | antique gold", (0.77, 0.42, 0.12), metallic=0.72, roughness=0.24)
light = material("Lantern glass | firefly", (1.0, 0.76, 0.30), emission=3.0)
sole = material("Boots | deep teal", (0.12, 0.29, 0.30), metallic=0.12, roughness=0.42)

def uv(name, loc, scale, mat, segments=32, rings=20):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=segments, ring_count=rings, radius=1, location=loc)
    obj = bpy.context.object
    obj.name = name
    obj.scale = scale
    obj.data.materials.append(mat)
    for p in obj.data.polygons: p.use_smooth = True
    return obj

def cyl(name, loc, radius, depth, mat, vertices=32):
    bpy.ops.mesh.primitive_cylinder_add(vertices=vertices, radius=radius, depth=depth, location=loc)
    obj = bpy.context.object
    obj.name = name
    obj.data.materials.append(mat)
    bevel = obj.modifiers.new("Soft crafted edges", "BEVEL")
    bevel.width = min(radius * 0.18, depth * 0.12)
    bevel.segments = 3
    obj.modifiers.new("Weighted corner normals", "WEIGHTED_NORMAL")
    return obj

def rod(name, a, b, radius, mat, vertices=16):
    mid = (Vector(a) + Vector(b)) * 0.5
    direction = Vector(b) - Vector(a)
    bpy.ops.mesh.primitive_cylinder_add(vertices=vertices, radius=radius, depth=direction.length, location=mid)
    obj = bpy.context.object
    obj.name = name
    obj.rotation_mode = "QUATERNION"
    obj.rotation_quaternion = direction.to_track_quat("Z", "Y")
    obj.data.materials.append(mat)
    bevel = obj.modifiers.new("Rounded", "BEVEL")
    bevel.width = radius * 0.35
    bevel.segments = 3
    obj.modifiers.new("Soft normals", "WEIGHTED_NORMAL")
    return obj

# Rounded velvet body and scalloped travelling cloak.
uv("Dream Sprite | body", (0, 0, 0.95), (0.59, 0.43, 0.75), cape)
verts, faces = [], []
segments, levels = 32, 6
for j in range(levels + 1):
    t = j / levels
    z = 1.42 - t * 1.19
    radius = 0.28 + 0.42 * t
    for i in range(segments):
        a = 2 * math.pi * i / segments
        wave = (0.045 * math.sin(6 * a) + 0.025 * math.sin(9 * a)) * (t ** 3)
        verts.append((math.cos(a) * (radius + wave), math.sin(a) * (radius + wave) * 0.68 + 0.07, z + wave * 0.5))
for j in range(levels):
    for i in range(segments):
        a = j * segments + i
        b = j * segments + (i + 1) % segments
        faces.append((a, b, b + segments, a + segments))
mesh = bpy.data.meshes.new("Scalloped velvet cloak mesh")
mesh.from_pydata(verts, [], faces)
mesh.materials.append(hood)
cloak = bpy.data.objects.new("Dream Sprite | hooded cloak", mesh)
bpy.context.collection.objects.link(cloak)
for poly in mesh.polygons: poly.use_smooth = True
solid = cloak.modifiers.new("Tailored cloth thickness", "SOLIDIFY")
solid.thickness = 0.045
bevel = cloak.modifiers.new("Soft cloth hem", "BEVEL")
bevel.width = 0.025
bevel.segments = 2

# Face tucked into the hood, luminous eyes, and little star-freckles.
uv("Dream Sprite | face", (0, -0.305, 1.45), (0.37, 0.19, 0.34), face)
for side in (-1, 1):
    uv("Dream Sprite | glowing eye", (side * 0.13, -0.472, 1.49), (0.057, 0.034, 0.11), eye, 24, 16)
for loc, scale in [((-0.35, -0.27, 1.75), 0.055), ((0.35, -0.27, 1.78), 0.04), ((0, -0.31, 1.98), 0.045)]:
    uv("Cloak | tiny star stitch", loc, (scale, scale * 0.45, scale), eye, 16, 12)

# Tiny boots peek beneath the cloak.
for side in (-1, 1):
    uv("Dream Sprite | boot", (side * 0.25, -0.02, 0.16), (0.19, 0.24, 0.12), sole)

# Gold handle and a faceted warm lantern carried at the sprite's side.
rod("Lantern | handle", (0.44, -0.02, 1.05), (0.79, -0.08, 0.70), 0.025, gold)
uv("Lantern | crown", (0.82, -0.09, 0.64), (0.13, 0.12, 0.07), gold, 24, 12)
cyl("Lantern | frame", (0.82, -0.09, 0.50), 0.12, 0.25, gold, 8)
uv("Lantern | glowing core", (0.82, -0.105, 0.50), (0.068, 0.07, 0.105), light, 24, 16)
cyl("Lantern | base", (0.82, -0.09, 0.36), 0.12, 0.05, gold, 8)
uv("Lantern | finial", (0.82, -0.09, 0.68), (0.035, 0.035, 0.05), gold, 16, 12)

# A single warm studio setup makes the native .blend useful for continued modeling.
world = bpy.data.worlds.new("Blue-hour studio") if not bpy.data.worlds else bpy.data.worlds[0]
bpy.context.scene.world = world
world.use_nodes = True
world.node_tree.nodes["Background"].inputs["Color"].default_value = (0.11, 0.14, 0.24, 1)
world.node_tree.nodes["Background"].inputs["Strength"].default_value = 0.42

def area(name, loc, power, color, size):
    bpy.ops.object.light_add(type="AREA", location=loc)
    obj = bpy.context.object
    obj.name = name
    obj.data.energy = power
    obj.data.color = color
    obj.data.shape = "DISK"
    obj.data.size = size
    obj.rotation_euler = (Vector((0, 0, 1)) - obj.location).to_track_quat("-Z", "Y").to_euler()

area("Key | soft lavender", (3, -5, 5), 470, (0.67, 0.72, 1.0), 4)
area("Fill | peach", (-4, -3, 2.7), 270, (1.0, 0.57, 0.34), 3)
area("Rim | moonlight", (1.5, 3, 4), 580, (0.48, 0.69, 1.0), 3)
bpy.ops.object.light_add(type="POINT", location=(0.82, -0.2, 0.52))
bpy.context.object.name = "Lantern | warm glow"
bpy.context.object.data.energy = 18
bpy.context.object.data.color = (1.0, 0.63, 0.22)
bpy.context.object.data.shadow_soft_size = 0.4

bpy.ops.object.camera_add(location=(3.4, -7.5, 3.0))
camera = bpy.context.object
camera.name = "Dream Sprite | portrait camera"
camera.rotation_euler = (Vector((0.05, -0.02, 1.02)) - camera.location).to_track_quat("-Z", "Y").to_euler()
camera.data.type = "ORTHO"
camera.data.ortho_scale = 4.35
bpy.context.scene.camera = camera

scene = bpy.context.scene
scene.render.engine = "BLENDER_EEVEE_NEXT"
scene.render.resolution_x = 1000
scene.render.resolution_y = 1000
scene.render.resolution_percentage = 100
scene.render.image_settings.file_format = "PNG"
scene.render.film_transparent = True
scene.view_settings.view_transform = "AgX"
scene.render.filepath = "//dream_sprite_preview.png"
scene.camera.data.lens = 55

# Select the character mesh for convenient editing; retain lights and camera in the scene.
bpy.ops.object.select_all(action="DESELECT")
for obj in bpy.context.scene.objects:
    if obj.name.startswith("Dream Sprite") or obj.name.startswith("Lantern") or obj.name.startswith("Cloak"):
        obj.select_set(True)
bpy.context.view_layer.objects.active = bpy.data.objects.get("Dream Sprite | body")

root = os.path.dirname(os.path.abspath(__file__)) + os.sep
bpy.ops.wm.save_as_mainfile(filepath=root + "dream_sprite.blend")
bpy.ops.export_scene.gltf(filepath=root + "dream_sprite.glb", export_format="GLB", use_selection=False)
print("Created Dream Sprite .blend and .glb in", root)
