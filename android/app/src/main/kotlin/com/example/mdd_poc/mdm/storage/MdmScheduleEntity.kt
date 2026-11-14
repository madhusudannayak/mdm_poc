package com.example.mdd_poc.mdm.storage

import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.Index
import androidx.room.PrimaryKey

/** Persisted allowed-time window for one application. */
@Entity(
    tableName = "application_schedules",
    indices = [Index(value = ["package_name"])],
)
data class MdmScheduleEntity(
    @PrimaryKey(autoGenerate = true) val id: Long = 0,
    @ColumnInfo(name = "package_name") val packageName: String,
    /** Minutes since local midnight, 0..1439. */
    @ColumnInfo(name = "start_minute_of_day") val startMinuteOfDay: Int,
    /** Minutes since local midnight; not after start means next day. */
    @ColumnInfo(name = "end_minute_of_day") val endMinuteOfDay: Int,
    /** Comma-separated ISO days (1 = Monday .. 7 = Sunday). */
    @ColumnInfo(name = "days_of_week") val daysOfWeek: String,
    @ColumnInfo(name = "enabled") val enabled: Boolean,
    @ColumnInfo(name = "created_at") val createdAt: Long,
    @ColumnInfo(name = "updated_at") val updatedAt: Long,
)
