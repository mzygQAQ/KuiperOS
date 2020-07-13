#ifndef __FAT12_H__
#define __FAT12_H__

#include "types.h"

typedef struct __attribute__ ((__packed__)) {
	/* first 3 bytes are JmpBoot */
	uint8_t  BS_JmpBoot[3];			// Jmp Inst
	uint8_t  BS_OEMName[8];		  	// OEM名称	
	uint16_t BPB_BytsPerSec;		// 每个扇区的字节数
	uint8_t  BPB_SecPerClus;		// 每簇占用的字节数
	/** ... */
	/** BootFlag: 0xAA55 */
} fat12_header_t;

typedef struct __attribute__ ((__packed__)) {
	int8_t 	 DIR_Name[11];			// file name
	uint8_t  DIR_Attr;				// file attr
	uint8_t  reserve[10];			// not use
	uint16_t DIR_WrtTime;			// last write time
	uint16_t DIR_WrtDate;			// last write date
	uint16_t DIR_FstClus;			// file start position
	uint32_t DIR_FileSize;			// file size
} fat12_root_entry_t;

#endif /* end of __FAT12_H__ */
