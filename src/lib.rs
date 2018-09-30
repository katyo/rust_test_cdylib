//#[cfg_attr(target_os = "linux", link_section = ".ctors")]
#[cfg_attr(target_os = "linux", link_section = ".init_array")]
pub static INITIALIZE: extern "C" fn() = myplugin_initialize;

#[no_mangle]
pub extern "C" fn myplugin_initialize() {
    println!("myplugin initialized");
}
