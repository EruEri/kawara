////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                            //
// This file is part of kawara: An litle X tiling program                                     //
// Copyright (C) 2023 Yves Ndiaye                                                             //
//                                                                                            //
// kawara is free software: you can redistribute it and/or modify it under the terms          //
// of the GNU General Public License as published by the Free Software Foundation,            //
// either version 3 of the License, or (at your option) any later version.                    //
//                                                                                            //
// kawara is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;        //
// without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR           //
// PURPOSE.  See the GNU General Public License for more details.                             //
// You should have received a copy of the GNU General Public License along with kawara.       //
// If not, see <http://www.gnu.org/licenses/>.                                                //
//                                                                                            //
////////////////////////////////////////////////////////////////////////////////////////////////

#define CAML_NAME_SPACE

#include <stdio.h>
#include <stdlib.h>
#include <stddef.h>

#include "caml/mlvalues.h"
#include "caml/alloc.h"
#include "caml/memory.h"
#include "caml/misc.h"

#include "xcb/xcb.h"
#include "xcb/xcb_ewmh.h"
#include "xcb/xproto.h"

static value value_of_xcb_connection(xcb_connection_t* connection) {
    value v = caml_alloc(1, Abstract_tag);
    *((xcb_connection_t **) Data_abstract_val(v)) = connection;
    return v;
}

static xcb_connection_t* xcb_connection_of_value(value caml_connection) {
    return *((xcb_connection_t **) Data_abstract_val(caml_connection));
}

static value value_of_xcb_ewmh_connection(xcb_ewmh_connection_t* ewmh) {
    value v = caml_alloc(1, Abstract_tag);
    *((xcb_ewmh_connection_t **) Data_abstract_val(v)) = ewmh;
    return v;
}

static xcb_ewmh_connection_t* xcb_ewmh_connection_of_value(value xbc_connection_ewmh) {
    return *((xcb_ewmh_connection_t **) Data_abstract_val(xbc_connection_ewmh));
}

// static value value_of_xcb_generic_event(xcb_generic_event_t* event) {
//     value v = caml_alloc(1, Abstract_tag);
//     *((xcb_generic_event_t **) Data_abstract_val(v)) = event;
//     return v;
// }

// static xcb_generic_event_t* xcb_generic_event_of_value(value caml_event) {
//     return *((xcb_generic_event_t **) Data_abstract_val(caml_event));
// }


CAMLprim value caml_xcb_connection(value caml_unit) {
    CAMLparam1(caml_unit);
    CAMLlocal2(caml_connection, caml_option);
    xcb_connection_t* connection = xcb_connect(NULL, NULL);
    int status = xcb_connection_has_error(connection);
    if (status == 0) { // Success 
        caml_connection = value_of_xcb_connection(connection);
        caml_option = caml_alloc_some(caml_connection);
    } else {
        caml_option = Val_none;
    }
    CAMLreturn(caml_option);
}


CAMLprim value caml_xcb_ewmh_connection_init(value caml_connection) {
    CAMLparam1(caml_connection);
    CAMLlocal2(caml_ewmh, caml_option);
    xcb_connection_t* connection = xcb_connection_of_value(caml_connection);
    xcb_ewmh_connection_t* ewmh = malloc(sizeof(xcb_ewmh_connection_t));
    caml_option = Val_none;
    if (!ewmh) {
        perror("Malloc");
        CAMLreturn(caml_option);
    }

    const struct xcb_setup_t* setup = xcb_get_setup(connection);
    xcb_screen_iterator_t screen_iterator = xcb_setup_roots_iterator(setup);
    const static uint32_t values[] = { XCB_EVENT_MASK_SUBSTRUCTURE_NOTIFY |  XCB_EVENT_MASK_STRUCTURE_NOTIFY};
    xcb_void_cookie_t cookie = xcb_change_window_attributes(connection, screen_iterator.data->root, XCB_CW_EVENT_MASK, values);
    xcb_flush(connection);

    xcb_intern_atom_cookie_t* cookies = xcb_ewmh_init_atoms(connection, ewmh);
    int r = xcb_ewmh_init_atoms_replies(ewmh, cookies, NULL);
    if ( r != 1) {
        CAMLreturn(caml_option);
    }
    caml_ewmh = value_of_xcb_ewmh_connection(ewmh);
    caml_option = caml_alloc_some(caml_ewmh);
    CAMLreturn(caml_option);
}

CAMLprim value caml_xcb_ewmh_connection_destroy(value caml_ewmh) {
    CAMLparam1(caml_ewmh);
    xcb_ewmh_connection_t* ewmh = xcb_ewmh_connection_of_value(caml_ewmh);

    free((void *) ewmh);
    CAMLreturn(Val_unit);
}


CAMLprim value caml_xcb_disconnect(value caml_connection) {
    CAMLparam1(caml_connection);
    xcb_connection_t* connection = xcb_connection_of_value(caml_connection);
    xcb_disconnect(connection);
    CAMLreturn(Val_unit);
}


CAMLprim value caml_xcb_ewmh_get_current_desktop(value caml_ewmh) {
    CAMLparam1(caml_ewmh);
    CAMLlocal2(caml_option, y);
    caml_option = Val_none;
    xcb_ewmh_connection_t* ewmh = xcb_ewmh_connection_of_value(caml_ewmh);
    uint32_t current_desktop;
    xcb_get_property_cookie_t desktop_cookie = xcb_ewmh_get_current_desktop(ewmh, 0);
    int status = xcb_ewmh_get_current_desktop_reply(ewmh, desktop_cookie,  &current_desktop, (void *) 0);
    if (!status) {
        CAMLreturn(caml_option);
    }
    caml_option = caml_alloc_some(Val_long(current_desktop));
    CAMLreturn(caml_option);
}

CAMLprim value caml_xcb_ewmh_get_number_of_desktops(value caml_ewmh, value caml_screen_nbr) {
    CAMLparam2(caml_ewmh, caml_screen_nbr);
    CAMLlocal2(caml_option, caml_dimension); 
    caml_option = Val_none;
    xcb_ewmh_connection_t* ewmh = xcb_ewmh_connection_of_value(caml_ewmh);
    xcb_get_property_cookie_t cookie = xcb_ewmh_get_number_of_desktops(ewmh, 0);
    uint32_t number_of_desktops;
    int status = xcb_ewmh_get_number_of_desktops_reply(ewmh, cookie, &number_of_desktops, NULL);
    if (!status) {
        CAMLreturn(caml_option);
    }
    caml_option = caml_alloc_some(Val_long(number_of_desktops));
    CAMLreturn(caml_option);
}

CAMLprim value caml_xcb_get_workarea(value caml_ewmh, value caml_screen_nbr) {
    CAMLparam2(caml_ewmh, caml_screen_nbr);
    CAMLlocal2(caml_option, caml_array); 
    caml_option = Val_none;
    xcb_ewmh_connection_t* ewmh = xcb_ewmh_connection_of_value(caml_ewmh);
    xcb_get_property_cookie_t cookie = xcb_ewmh_get_workarea( ewmh, 0);
    xcb_ewmh_get_workarea_reply_t working_aera = {};
    int status = xcb_ewmh_get_workarea_reply(ewmh, cookie, &working_aera, NULL);
    if (!status) {
        CAMLreturn(caml_option);
    }

    caml_array = caml_alloc(working_aera.workarea_len, 0);
    for (uint32_t i = 0; i < working_aera.workarea_len; i += 1) {
        xcb_ewmh_geometry_t geomery = working_aera.workarea[i];
        value caml_geometry = caml_alloc(4, 0);
        Store_field(caml_geometry, 0, Val_long(geomery.x));
        Store_field(caml_geometry, 1, Val_long(geomery.y));
        Store_field(caml_geometry, 2, Val_long(geomery.width));
        Store_field(caml_geometry, 3, Val_long(geomery.height));
        Field(caml_array, i) = caml_geometry;
    }
    caml_option = caml_alloc_some(caml_array);
    CAMLreturn(caml_option);
}

CAMLprim value caml_xcb_ewmh_get_desktop_geometry(value caml_ewmh, value caml_desktop_index) {
    CAMLparam2(caml_ewmh, caml_desktop_index);
    CAMLlocal2(caml_option, caml_dimension);
    caml_option = Val_none;
    xcb_ewmh_connection_t* ewmh = xcb_ewmh_connection_of_value(caml_ewmh);
    int screen_nbr = Long_val(caml_desktop_index);
    uint32_t width;
    uint32_t height;
    xcb_get_property_cookie_t desktop_cookie = xcb_ewmh_get_desktop_geometry(ewmh, screen_nbr);
    uint8_t status = xcb_ewmh_get_desktop_geometry_reply(ewmh,  desktop_cookie, &width, &height, NULL);
    if (status != 1) {
        CAMLreturn(caml_option);
    }
    caml_dimension = caml_alloc_2(0, Long_val(width), Long_val(height));
    caml_option = caml_alloc_some(caml_dimension);
    CAMLreturn(caml_option);
}

CAMLprim value caml_xcb_ewmh_connection_get_desktop_layout(value caml_ewmh, value caml_desktop_index) {
    CAMLparam2(caml_ewmh, caml_desktop_index);
    CAMLlocal2(caml_option, caml_dimension);
    caml_option = Val_none;
    xcb_ewmh_connection_t* ewmh = xcb_ewmh_connection_of_value(caml_ewmh);
    int screen_nbr = Long_val(caml_desktop_index);
    xcb_get_property_cookie_t desktop_cookie = xcb_ewmh_get_desktop_layout(ewmh, screen_nbr);
    xcb_ewmh_get_desktop_layout_reply_t desktop_layouts = {};
    uint8_t status = xcb_ewmh_get_desktop_layout_reply(
        ewmh, 
        desktop_cookie, 
        &desktop_layouts, 
        NULL
    );
    if (status != 1) {
        CAMLreturn(caml_option);
    }
    value orientation = Val_long(desktop_layouts.orientation);
    value columns = Val_long(desktop_layouts.columns);
    value rows = Val_long(desktop_layouts.rows);
    value starting_corner = Val_long(desktop_layouts.starting_corner);
    caml_dimension = caml_alloc_4(0, orientation, columns, rows, starting_corner);
    caml_option = caml_alloc_some(caml_dimension);
    CAMLreturn(caml_option);
}

CAMLprim value caml_xcb_wait_for_event(value caml_ewmh) {
    CAMLparam1(caml_ewmh);
    CAMLlocal2(caml_event, caml_option);
    caml_option = Val_none;
    xcb_ewmh_connection_t* ewmh = xcb_ewmh_connection_of_value(caml_ewmh);
    xcb_generic_event_t* event = xcb_wait_for_event(ewmh->connection);
    if (!event) {CAMLreturn(caml_option); }

    switch (event->response_type & ~0x80) {
    case XCB_CREATE_NOTIFY: {
        xcb_create_notify_event_t* e = (xcb_create_notify_event_t*) event;  
        // XcbCreate
        // Block , Tag 0 
        caml_event = caml_alloc_1(0, caml_copy_int32(e->window));
        break;
    }
    case XCB_DESTROY_NOTIFY: {
        xcb_destroy_notify_event_t* e = (xcb_destroy_notify_event_t*) event;  
        // XcbDestroy
        // Block , Tag 1
        caml_event = caml_alloc_1(1, caml_copy_int32(e->window));
        break;
    }
    default:
        // XcbIgnoreEvent
        // Non block Tag 0
        caml_event = Val_int(0);
        break;
    }
    free((void *) event);
    caml_option = caml_alloc_some(caml_event);
    CAMLreturn(caml_option);
}

CAMLprim value caml_xcb_window_compare(value caml_windows_lhs, value caml_windows_rhs) {
    CAMLparam2(caml_windows_lhs, caml_windows_rhs);
    uint32_t lhs = Int32_val(caml_windows_lhs);
    uint32_t rhs = Int32_val(caml_windows_rhs);

    if (lhs == rhs) { CAMLreturn(Val_int(0)); }
    else if (lhs > rhs) { CAMLreturn(1); }
    else { CAMLreturn(-1); }
}

CAMLprim value caml_xcb_move_window(
    value caml_ewmh, value caml_window, value caml_x,
    value caml_y, value caml_width, value caml_height
) {
    CAMLparam5(caml_ewmh, caml_window, caml_x, caml_y, caml_width);
    CAMLxparam1(caml_height);
    xcb_ewmh_connection_t* ewmh = xcb_ewmh_connection_of_value(caml_ewmh);
    xcb_window_t window = (uint32_t) Int32_val(caml_window);
    int x = Int_val(caml_x);
    int y = Int_val(caml_y);
    int width = Int_val(caml_width);
    int height = Int_val(caml_height);
    const int values[] = {x, y, width, height};
    uint16_t config = XCB_CONFIG_WINDOW_X | XCB_CONFIG_WINDOW_Y | XCB_CONFIG_WINDOW_WIDTH | XCB_CONFIG_WINDOW_HEIGHT;
    xcb_configure_window(
        ewmh->connection, 
        window, config, 
        values
    );

    CAMLreturn(Val_unit);
}

CAMLprim value caml_xcb_move_window_bytecode(value* argv, int argn) {
    return caml_xcb_move_window(
        argv[0], argv[1], argv[2], argv[3], 
        argv[4], argv[5]
    );
}