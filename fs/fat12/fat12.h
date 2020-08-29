#ifndef __FAT12_H__
#define __FAT12_H__

#include <kuiper/types.h>

// 扇区   长度    内容
//  0    1byte  引导程序
//  1    9byte  FAT_Table_1
//  10   9byte  FAT_Table_2
//  19   14byte 目录文件项
//  33   ...    文件数据信息

typedef struct __attribute__ ((__packed__)) {
	u8_t  BS_JmpBoot[3];	    // Jmp Inst
	u8_t  BS_OEMName[8];		// OEM名称
	u16_t BPB_BytsPerSec;		// 每个扇区的字节数
	u8_t  BPB_SecPerClus;		// 每簇占用的字节数
	/** ... */
	u16_t BOOT_FLAG;           // 0xaa55

} fat12_header_t;

typedef struct __attribute__ ((__packed__)) {
	u8_t  DIR_Name[11];	        // 文件名8字节扩展名3位
	u8_t  DIR_Attr;				// 文件的属性
	u8_t  reserve[10];			// 预留空间
	u16_t DIR_WrtTime;			// 最近写入时间
	u16_t DIR_WrtDate;			// 最近写入日期
	u16_t DIR_FstClus;			// 文件数据起点位置
	u32_t DIR_FileSize;			// 文件的大小
} fat12_root_entry_t;

#endif /* end of __FAT12_H__ */
