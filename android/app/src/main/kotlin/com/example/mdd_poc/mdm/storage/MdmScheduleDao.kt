package com.example.mdd_poc.mdm.storage

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.Query
import androidx.room.Update

@Dao
interface MdmScheduleDao {
    @Query("SELECT * FROM application_schedules ORDER BY package_name, start_minute_of_day")
    suspend fun getAll(): List<MdmScheduleEntity>

    @Query("SELECT * FROM application_schedules WHERE id = :id")
    suspend fun getById(id: Long): MdmScheduleEntity?

    @Insert
    suspend fun insert(entity: MdmScheduleEntity): Long

    @Update
    suspend fun update(entity: MdmScheduleEntity): Int

    @Query("DELETE FROM application_schedules WHERE id = :id")
    suspend fun deleteById(id: Long): Int
}
