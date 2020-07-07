#ifndef __FAT12_H__
#define __FAT12_H__

#include "types.h"

typedef struct {

} fat12_header_t;

typedef struct {
	int8_t 	 DIR_Name[11];	// file name
	uint8_t  DIR_Attr;		// file attr
	uint8_t  reserve[10];	// not use
	uint16_t DIR_WrtTime;	// last write time
	uint16_t DIR_WrtDate;	// last write date
	uint16_t DIR_FstClus;	// file start position
	uint32_t DIR_FileSize;	// file size
} fat12_root_entry_t;

#endif /* end of __FAT12_H__ */
