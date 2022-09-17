# laygo2 layout export magic(tcl) script.

# _laygo2_create_layout:
# parameters:
#  - libpath: path of folder for cellfile
#  - _cellname: name of cellfile (without .mag)
#  - techname: [name of tech file[.tech]] in the system tech folder 
# flow:
# 1. create cell (if _cellname already loaded on db, just load it to layout window -> need to clear before run script but I don't know how to clear yet. So you need to shutdown and run magic again to reset db before run script)
# 2. load tech: tk_path tech load techname(include path, no need a suffix .tech)
# 3. load cell: 
# 4. select layout and turn into editmode
# 5. return cv

proc _laygo2_create_layout {libpath _cellname techname} {
    cellname create $_cellname
#    set techFileName_full [tech filename]
#    set nameidx [expr [string last / $techFileName_full] + 1 ]
#    set techFileName [string range $techFileName_full $nameidx [string length $techFileName_full] ]
#    if { $techFileName != $techname } {
#        tech load $techname
#    }
    if { [tech name] != $techname } {
        tech load $techname
    }
    cellname filepath $_cellname $libpath
    load $_cellname
    select top cell
    edit
# if same named cell already exist, erase it.
    set ilist [cellname list childinst]
    set len [llength $ilist]
    for { set idx 0 } { $idx < $len } { incr idx 1 } {
        set bracket [string first \\ [lindex $ilist $idx]]
        if { $bracket != -1 } {
            set instname [string range [lindex $ilist $idx] 0 [expr $bracket - 1] ]
        } else {
            set instname [lindex $ilist $idx]
        }
        select cell $instname
        delete
    }
    select top cell
    select area
    delete
}; # create new edit cell

proc _laygo2_open_layout {libpath _cellname techname} {
    if { [tech filename] != $techname } {
        tech load $techname
    }
    load ${libpath}/${_cellname}
    select
    edit
}; # open layout file

proc _laygo2_clear_layout {} {
    select top cell
    select area
    delete
}; # we can't delete subcells with this -> must get children instance name list 
proc _laygo2_save_and_close_layout {cv} {
    $cv save
    set frameName [string range $cv 0 [expr [string first . $cv 1] - 1]]
    closewrapper $frameName
}; # save layout and close window
#don't use now
# TODO: should find way to unload cell from layout

#more metal layers may added
proc _laygo2_generate_rect {layer bbox} { 
    box values [lindex [lindex $bbox 0] 0] [lindex [lindex $bbox 0] 1] [lindex [lindex $bbox 1] 0] [lindex [lindex $bbox 1] 1]
    switch -exact -- $layer {
        M1 { paint metal1 }
        M2 { paint metal2 }
        M3 { paint metal3 }
        M4 { paint metal4 }
        M5 { paint metal5 }
        default { paint $layer }
    }
}; #create a rectangle

proc _laygo2_generate_pin {name layer bbox} {
    set pin_w [ expr [lindex [lindex $bbox 1] 0] - [lindex [lindex $bbox 0] 0] ]
    set pin_cx [expr [expr [lindex [lindex $bbox 1] 0] + [lindex [lindex $bbox 0] 0]] / 2]
    set pin_cy [expr [expr [lindex [lindex $bbox 1] 1] + [lindex [lindex $bbox 0] 1]] / 2]
    set pin_h [ expr [lindex [lindex $bbox 1] 1] - [lindex [lindex $bbox 0] 1] ]
    switch -exact -- $layer {
        M1 { set layer_real metal1 }
        M2 { set layer_real metal2 }
        M3 { set layer_real metal3 }
        M4 { set layer_real metal4 }
        M5 { set layer_real metal5 }
        default { set layer_real $layer }
    }
    if {$pin_w >= $pin_h} {
        box values $pin_cx $pin_cy $pin_cx $pin_cy
        label $name FreeSans $pin_h 0 0 0 center $layer_real
    } else {
        box values $pin_cx $pin_cy $pin_cx $pin_cy
        label $name FreeSans $pin_w 90 0 0 center $layer_real
    }
    box values $pin_cx $pin_cy $pin_cx $pin_cy
    select area label
    setlabel layer $layer_real
}; #print label on layer bbox

# notice: filename must have form of path/cellname.mag otherwise, segmentation fault occur when import one cellfile twice
# param: 
#     -name: instanceName
#     -loc: xy location of lower-left
#     -orient: R0(default), MX(v), MY(h), R90(90), R180(180), MXY(270)
#     -num_rows: (mosaic) number of instances for y direction
#     -num_cols: (mosaic) number of instances for x direction
#     -sp_rows: (mosaic) y_pitch between adjacent instance
#     -sp_cols: (mosaic) x_pitch between adjacent instance
# TODO:
#     - make routine for checking if cellfile exist
# flow:
#     check if array or single
#     1.case_single -> getcell
#     2.case_array -> getcell -> select -> box size sp_cols sp_rows -> array num_cols num_rows

proc _laygo2_generate_instance { name libpath _cellname loc orient num_rows num_cols sp_rows sp_cols} {
        switch -exact -- $orient {
            R0 { set orientation 0 }
            MX { set orientation v }
            MY { set orientation h }
            R90 { set orientation 90 }
            R180 { set orientation 180 }
            MXY { set orientation 270 }
            default { set orientation 0 }
        }
        box position [lindex $loc 0] [lindex $loc 1]
        if { $orientation == 0 } {
#            set instName [ getcell ${libpath}/${_cellname}.mag child 0 0 parent ll ]
            set instName [ getcell ${_cellname}.mag child 0 0 parent ll ]
        } else {
#            set instName [ getcell ${libpath}/${_cellname}.mag child 0 0 parent ll $orientation 0 0 ]
            set instName [ getcell ${_cellname}.mag child 0 0 parent ll $orientation 0 0 ]
        }
        select cell $instName
        identify $name
        if { ($num_cols != 1) || ($num_rows != 1) } { ; # array command to make mosaic
            box size $sp_cols $sp_rows
            array $num_cols $num_rows
        }
};

proc _laygo2_test {libpath _cellname techname} {
# load layout file and clear layout
    _laygo2_open_layout $libpath $_cellname $techname
#generate rects. param: {cv layer bbox}
    _laygo2_generate_rect nwell {{0 98} {126 231}}
    _laygo2_generate_rect pwell {{0 -28} {126 98}}
    _laygo2_generate_rect ntransistor {{56 28} {77 42}}
    _laygo2_generate_rect ptransistor {{56 161} {98 175}}
    _laygo2_generate_rect ndiffusion {{56 42} {77 49}}
    _laygo2_generate_rect ndiffusion {{56 21} {77 28}}
    _laygo2_generate_rect pdiffusion {{56 175} {98 182}}
    _laygo2_generate_rect pdiffusion {{56 154} {98 161}}
    _laygo2_generate_rect ndcontact {{56 49} {77 70}}
    _laygo2_generate_rect ndcontact {{56 0} {77 21}}
    _laygo2_generate_rect pdcontact {{56 182} {98 203}}
    _laygo2_generate_rect pdcontact {{56 133} {98 154}}
    _laygo2_generate_rect polycontact {{14 91} {42 119}}
#generate pin. param: {cv name layer bbox}
    _laygo2_generate_pin IN polycontact {{12 102} {30 108}}
#save and close
    save
}

# exporting laygo2_train__nand_2x
_laygo2_create_layout ./laygo2_example/magic_layout/laygo2_train laygo2_train_nand_2x sky130A
_laygo2_generate_instance MN0_IBNDL0 ./laygo2_example/magic_layout/skywater130_microtemplates_dense nmos13_fast_boundary { 0.0  0.0  } R0 1 1 0 0 ; # for the Instance object MN0_IBNDL0 
_laygo2_generate_instance MN0_IM0 ./laygo2_example/magic_layout/skywater130_microtemplates_dense nmos13_fast_center_nf2 { 72.0  0.0  } R0 1 1 504.0  144.0  ; # for the Instance object MN0_IM0 
_laygo2_generate_instance MN0_IBNDR0 ./laygo2_example/magic_layout/skywater130_microtemplates_dense nmos13_fast_boundary { 216.0  0.0  } R0 1 1 0 0 ; # for the Instance object MN0_IBNDR0 
_laygo2_generate_rect M2 { { 54.0  345.0  } { 234.0  375.0  } } ; # for the Rect object MN0_RG0 
_laygo2_generate_instance MN0_IVG0 ./laygo2_example/magic_layout/skywater130_microtemplates_dense via_M1_M2_0 { 144.0  360.0  } R0 1 1 504.0  144.0  ; # for the Instance object MN0_IVG0 
_laygo2_generate_rect M2 { { 54.0  201.0  } { 234.0  231.0  } } ; # for the Rect object MN0_RD0 
_laygo2_generate_instance MN0_IVD0 ./laygo2_example/magic_layout/skywater130_microtemplates_dense via_M1_M2_0 { 144.0  216.0  } R0 1 1 504.0  144.0  ; # for the Instance object MN0_IVD0 
_laygo2_generate_rect M2 { { -10.0  -30.0  } { 298.0  30.0  } } ; # for the Rect object MN0_RRAIL0 
_laygo2_generate_rect M1 { { 57.0  -20.0  } { 87.0  164.0  } } ; # for the Rect object MN0_RTIE0 
_laygo2_generate_rect M1 { { 201.0  -20.0  } { 231.0  164.0  } } ; # for the Rect object MN0_RTIE1 
_laygo2_generate_instance MN0_IVTIED0 ./laygo2_example/magic_layout/skywater130_microtemplates_dense via_M1_M2_1 { 72.0  0.0  } R0 1 2 504.0  144.0  ; # for the Instance object MN0_IVTIED0 
_laygo2_generate_instance MP0_IBNDL0 ./laygo2_example/magic_layout/skywater130_microtemplates_dense pmos13_fast_boundary { 0.0  1008.0  } MX 1 1 0 0 ; # for the Instance object MP0_IBNDL0 
_laygo2_generate_instance MP0_IM0 ./laygo2_example/magic_layout/skywater130_microtemplates_dense pmos13_fast_center_nf2 { 72.0  1008.0  } MX 1 1 504.0  144.0  ; # for the Instance object MP0_IM0 
_laygo2_generate_instance MP0_IBNDR0 ./laygo2_example/magic_layout/skywater130_microtemplates_dense pmos13_fast_boundary { 216.0  1008.0  } MX 1 1 0 0 ; # for the Instance object MP0_IBNDR0 
_laygo2_generate_rect M2 { { 54.0  663.0  } { 234.0  633.0  } } ; # for the Rect object MP0_RG0 
_laygo2_generate_instance MP0_IVG0 ./laygo2_example/magic_layout/skywater130_microtemplates_dense via_M1_M2_0 { 144.0  648.0  } MX 1 1 504.0  144.0  ; # for the Instance object MP0_IVG0 
_laygo2_generate_rect M2 { { 54.0  807.0  } { 234.0  777.0  } } ; # for the Rect object MP0_RD0 
_laygo2_generate_instance MP0_IVD0 ./laygo2_example/magic_layout/skywater130_microtemplates_dense via_M1_M2_0 { 144.0  792.0  } MX 1 1 504.0  144.0  ; # for the Instance object MP0_IVD0 
_laygo2_generate_rect M2 { { -10.0  1038.0  } { 298.0  978.0  } } ; # for the Rect object MP0_RRAIL0 
_laygo2_generate_rect M1 { { 57.0  1028.0  } { 87.0  844.0  } } ; # for the Rect object MP0_RTIE0 
_laygo2_generate_rect M1 { { 201.0  1028.0  } { 231.0  844.0  } } ; # for the Rect object MP0_RTIE1 
_laygo2_generate_instance MP0_IVTIED0 ./laygo2_example/magic_layout/skywater130_microtemplates_dense via_M1_M2_1 { 72.0  1008.0  } MX 1 2 504.0  144.0  ; # for the Instance object MP0_IVTIED0 
_laygo2_generate_instance MN1_IBNDL0 ./laygo2_example/magic_layout/skywater130_microtemplates_dense nmos13_fast_boundary { 288.0  0.0  } R0 1 1 0 0 ; # for the Instance object MN1_IBNDL0 
_laygo2_generate_instance MN1_IM0 ./laygo2_example/magic_layout/skywater130_microtemplates_dense nmos13_fast_center_nf2 { 360.0  0.0  } R0 1 1 504.0  144.0  ; # for the Instance object MN1_IM0 
_laygo2_generate_instance MN1_IBNDR0 ./laygo2_example/magic_layout/skywater130_microtemplates_dense nmos13_fast_boundary { 504.0  0.0  } R0 1 1 0 0 ; # for the Instance object MN1_IBNDR0 
_laygo2_generate_rect M2 { { 342.0  345.0  } { 522.0  375.0  } } ; # for the Rect object MN1_RG0 
_laygo2_generate_instance MN1_IVG0 ./laygo2_example/magic_layout/skywater130_microtemplates_dense via_M1_M2_0 { 432.0  360.0  } R0 1 1 504.0  144.0  ; # for the Instance object MN1_IVG0 
_laygo2_generate_rect M2 { { 322.0  201.0  } { 542.0  231.0  } } ; # for the Rect object MN1_RS0 
_laygo2_generate_instance MN1_IVS0 ./laygo2_example/magic_layout/skywater130_microtemplates_dense via_M1_M2_0 { 360.0  216.0  } R0 1 2 504.0  144.0  ; # for the Instance object MN1_IVS0 
_laygo2_generate_rect M2 { { 342.0  129.0  } { 522.0  159.0  } } ; # for the Rect object MN1_RD0 
_laygo2_generate_instance MN1_IVD0 ./laygo2_example/magic_layout/skywater130_microtemplates_dense via_M1_M2_0 { 432.0  144.0  } R0 1 1 504.0  144.0  ; # for the Instance object MN1_IVD0 
_laygo2_generate_rect M2 { { 278.0  -30.0  } { 586.0  30.0  } } ; # for the Rect object MN1_RRAIL0 
_laygo2_generate_instance MP1_IBNDL0 ./laygo2_example/magic_layout/skywater130_microtemplates_dense pmos13_fast_boundary { 288.0  1008.0  } MX 1 1 0 0 ; # for the Instance object MP1_IBNDL0 
_laygo2_generate_instance MP1_IM0 ./laygo2_example/magic_layout/skywater130_microtemplates_dense pmos13_fast_center_nf2 { 360.0  1008.0  } MX 1 1 504.0  144.0  ; # for the Instance object MP1_IM0 
_laygo2_generate_instance MP1_IBNDR0 ./laygo2_example/magic_layout/skywater130_microtemplates_dense pmos13_fast_boundary { 504.0  1008.0  } MX 1 1 0 0 ; # for the Instance object MP1_IBNDR0 
_laygo2_generate_rect M2 { { 342.0  663.0  } { 522.0  633.0  } } ; # for the Rect object MP1_RG0 
_laygo2_generate_instance MP1_IVG0 ./laygo2_example/magic_layout/skywater130_microtemplates_dense via_M1_M2_0 { 432.0  648.0  } MX 1 1 504.0  144.0  ; # for the Instance object MP1_IVG0 
_laygo2_generate_rect M2 { { 342.0  807.0  } { 522.0  777.0  } } ; # for the Rect object MP1_RD0 
_laygo2_generate_instance MP1_IVD0 ./laygo2_example/magic_layout/skywater130_microtemplates_dense via_M1_M2_0 { 432.0  792.0  } MX 1 1 504.0  144.0  ; # for the Instance object MP1_IVD0 
_laygo2_generate_rect M2 { { 278.0  1038.0  } { 586.0  978.0  } } ; # for the Rect object MP1_RRAIL0 
_laygo2_generate_rect M1 { { 345.0  1028.0  } { 375.0  844.0  } } ; # for the Rect object MP1_RTIE0 
_laygo2_generate_rect M1 { { 489.0  1028.0  } { 519.0  844.0  } } ; # for the Rect object MP1_RTIE1 
_laygo2_generate_instance MP1_IVTIED0 ./laygo2_example/magic_layout/skywater130_microtemplates_dense via_M1_M2_1 { 360.0  1008.0  } MX 1 2 504.0  144.0  ; # for the Instance object MP1_IVTIED0 
_laygo2_generate_rect M2 { { 350.0  345.0  } { 442.0  375.0  } } ; # for the Rect object NoName_0 
_laygo2_generate_instance NoName_1 ./laygo2_example/magic_layout/skywater130_microtemplates_dense via_M2_M3_0 { 360.0  360.0  } R0 1 1 0 0 ; # for the Instance object NoName_1 
_laygo2_generate_rect M2 { { 350.0  633.0  } { 442.0  663.0  } } ; # for the Rect object NoName_2 
_laygo2_generate_instance NoName_3 ./laygo2_example/magic_layout/skywater130_microtemplates_dense via_M2_M3_0 { 360.0  648.0  } R0 1 1 0 0 ; # for the Instance object NoName_3 
_laygo2_generate_rect M3 { { 345.0  345.0  } { 375.0  663.0  } } ; # for the Rect object NoName_4 
_laygo2_generate_instance NoName_5 ./laygo2_example/magic_layout/skywater130_microtemplates_dense via_M2_M3_0 { 144.0  360.0  } R0 1 1 0 0 ; # for the Instance object NoName_5 
_laygo2_generate_rect M3 { { 129.0  345.0  } { 159.0  663.0  } } ; # for the Rect object NoName_6 
_laygo2_generate_instance NoName_7 ./laygo2_example/magic_layout/skywater130_microtemplates_dense via_M2_M3_0 { 144.0  648.0  } R0 1 1 0 0 ; # for the Instance object NoName_7 
_laygo2_generate_rect M2 { { 134.0  777.0  } { 442.0  807.0  } } ; # for the Rect object NoName_8 
_laygo2_generate_rect M2 { { 134.0  201.0  } { 370.0  231.0  } } ; # for the Rect object NoName_9 
_laygo2_generate_instance NoName_10 ./laygo2_example/magic_layout/skywater130_microtemplates_dense via_M2_M3_0 { 432.0  144.0  } R0 1 1 0 0 ; # for the Instance object NoName_10 
_laygo2_generate_rect M3 { { 417.0  129.0  } { 447.0  807.0  } } ; # for the Rect object NoName_11 
_laygo2_generate_instance NoName_12 ./laygo2_example/magic_layout/skywater130_microtemplates_dense via_M2_M3_0 { 432.0  792.0  } R0 1 1 0 0 ; # for the Instance object NoName_12 
_laygo2_generate_rect M2 { { -20.0  -30.0  } { 596.0  30.0  } } ; # for the Rect object NoName_13 
_laygo2_generate_rect M2 { { -20.0  978.0  } { 596.0  1038.0  } } ; # for the Rect object NoName_14 
_laygo2_generate_pin B M3 { { 129.0  360.0  } { 159.0  648.0  } }  ; # for the Pin object B 
_laygo2_generate_pin A M3 { { 345.0  360.0  } { 375.0  648.0  } }  ; # for the Pin object A 
_laygo2_generate_pin O M3 { { 417.0  144.0  } { 447.0  792.0  } }  ; # for the Pin object O 
_laygo2_generate_pin VSS M2 { { 0.0  -30.0  } { 576.0  30.0  } }  ; # for the Pin object VSS 
_laygo2_generate_pin VDD M2 { { 0.0  978.0  } { 576.0  1038.0  } }  ; # for the Pin object VDD 
save
