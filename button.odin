package main


import "core:fmt"
import "core:strings"
import sdl "vendor:sdl2"
import "vendor:sdl2/ttf"

Button :: struct {
	rect:         ^sdl.FRect,
	bg_color:     sdl.Color,
	text_texture: ^sdl.Texture,
	text_rect:    ^sdl.FRect,
}

init_button :: proc(
	r: ^sdl.Renderer,
	f: ^ttf.Font,
	rect: sdl.FRect,
	text: string,
	bg_color: sdl.Color,
	text_color: sdl.Color = sdl.Color{1, 1, 1, 255},
) -> Button {
	text_surf := ttf.RenderText_Blended(f, strings.clone_to_cstring(text), text_color)
	text_texture := sdl.CreateTextureFromSurface(r, text_surf)
	defer sdl.FreeSurface(text_surf)

	// NOTE: This pointer needs to be initialized with `new` because it's used
	// outside of the scope of this procedure.
	tr := new(sdl.FRect)
	tr.x = rect.x + rect.w / 2 - f32(text_surf.w / 2)
	tr.y = (rect.y + rect.h / 2) - f32(text_surf.h / 2)
	tr.w = f32(text_surf.w)
	tr.h = f32(text_surf.h)

	return Button {
		rect = new_clone(rect),
		text_texture = text_texture,
		bg_color = bg_color,
		text_rect = tr,
	}
}

button_is_pressed :: proc(btn: ^Button, event: sdl.MouseButtonEvent) -> bool {
	return(
		event.button == 1 &&
		f32(event.x) >= btn.rect.x &&
		f32(event.x) <= btn.rect.x + btn.rect.w &&
		f32(event.y) >= btn.rect.y &&
		f32(event.y) <= btn.rect.y + btn.rect.h \
	)
}

button_render :: proc(btn: ^Button, r: ^sdl.Renderer, show_center: bool = false) {
	sdl.SetRenderDrawColor(r, btn.bg_color.r, btn.bg_color.g, btn.bg_color.b, btn.bg_color.a)
	sdl.RenderFillRectF(r, btn.rect)

	if show_center {
		sdl.SetRenderDrawColor(r, 0, 0, 0, 255)
		sdl.RenderFillRectF(r, &sdl.FRect{btn.rect.x, btn.rect.y + btn.rect.h / 2, btn.rect.w, 1})
		sdl.RenderFillRectF(r, &sdl.FRect{btn.rect.x + btn.rect.w / 2, btn.rect.y, 1, btn.rect.h})
	}

	sdl.RenderCopyF(r, btn.text_texture, nil, btn.text_rect)
}

button_clean :: proc(btn: ^Button) {
	free(btn.rect)
	free(btn.text_rect)
	sdl.DestroyTexture(btn.text_texture)
}
