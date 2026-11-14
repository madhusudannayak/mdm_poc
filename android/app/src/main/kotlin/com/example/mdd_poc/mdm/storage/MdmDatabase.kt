package com.example.mdd_poc.mdm.storage

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase

@Database(entities = [MdmScheduleEntity::class], version = 1, exportSchema = false)
abstract class MdmDatabase : RoomDatabase() {
    abstract fun scheduleDao(): MdmScheduleDao

    companion object {
        private const val DATABASE_NAME = "mdm.db"

        fun create(context: Context): MdmDatabase =
            Room.databaseBuilder(context.applicationContext, MdmDatabase::class.java, DATABASE_NAME)
                .build()
    }
}
