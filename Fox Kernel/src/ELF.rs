use crate::arch::Memory::PageTableImpl;
use crate::PageFrame::{Allocate,Free};

pub fn LoadELF(data: &[u8], pt: &mut PageTableImpl) -> Result<usize,()> {
    match xmas_elf::ElfFile::new(data) {
        Ok(elf) => {
            for i in elf.program_iter() {
                if i.align() != 0x1000 {
                    log::error!("Failed to load ELF: \"One of the program sections is not page aligned\"");
                    return Err(());
                }
                let size = i.mem_size().div_ceil(0x1000) * 0x1000;
                let pages = Allocate(size).unwrap();
                let flags = i.flags();
                unsafe {core::ptr::copy((data.as_ptr() as u64 + i.offset()) as *const u8,pages,i.file_size() as usize);}
                if !crate::Memory::MapPages(pt,i.virtual_addr() as usize,pages as usize - crate::arch::PHYSMEM_BEGIN as usize,size as usize,flags.is_write(),flags.is_execute()) {
                    Free(pages,size);
                    log::error!("Failed to load ELF: \"Memory Mapping Failed (Partially loaded!)\"");
                    return Err(());
                }
            }
            return Ok(0);
        }
        Err(e) => {
            log::error!("Failed to load ELF: \"{}\"", e);
            return Err(());
        }
    }
}