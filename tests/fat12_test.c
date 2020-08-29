
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

typedef unsigned char        u8_t;
typedef unsigned short       u16_t;
typedef unsigned int         u32_t;
typedef signed char          i8_t;
typedef signed short         i16_t;
typedef signed int           i32_t;

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


int main(int argc, const char **argv)
{
    char *file_path = "../build/data.img";
    FILE *pFile = fopen(file_path, "r");
    if (!pFile) {
        fprintf(stderr, "open file error: %s", file_path);
        return -1;
    }

    char buffer[512] = {0};
    size_t nread =  fread(buffer, 1, 512, pFile);
    if(nread != 512) {
        fprintf(stderr, "fread error");
        return -1;
    }

    printf("%c\n", buffer[510]);
    printf("%c\n", buffer[511]);

    fat12_header_t fatHeader;
    fatHeader.BPB_BytsPerSec = 512;
    fat12_root_entry_t rootEntry;

    // foreach
    for (int i = 0; i <  9; ++i) {
        fseek(pFile, (19 * fatHeader.BPB_BytsPerSec + i * sizeof(fat12_root_entry_t)), SEEK_SET);
        fread((void*)&rootEntry, (size_t)1 , sizeof(fat12_root_entry_t), pFile);
        printf("DIR_NAME: %s\n", rootEntry.DIR_Name);
        printf("DIR_WrtDate:%d\n", rootEntry.DIR_WrtDate);
        printf("DIR_FileSize: %d\n", rootEntry.DIR_FileSize);
        printf("======================\n");
    }

    return 0;
}