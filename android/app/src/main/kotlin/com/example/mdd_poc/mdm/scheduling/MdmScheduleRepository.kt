package com.example.mdd_poc.mdm.scheduling

import com.example.mdd_poc.mdm.models.ApplicationSchedule
import com.example.mdd_poc.mdm.storage.MdmScheduleDao
import com.example.mdd_poc.mdm.storage.MdmScheduleEntity

/** Persists schedules with Room so they survive process death and reboot. */
class MdmScheduleRepository(private val dao: MdmScheduleDao) {

    suspend fun getAll(): List<ApplicationSchedule> = dao.getAll().map(::toModel)

    suspend fun getById(id: Long): ApplicationSchedule? = dao.getById(id)?.let(::toModel)

    suspend fun insert(schedule: ApplicationSchedule): ApplicationSchedule {
        val now = System.currentTimeMillis()
        val id = dao.insert(toEntity(schedule.copy(id = 0), createdAt = now, updatedAt = now))
        return schedule.copy(id = id)
    }

    /** Returns false when no schedule with that id exists. */
    suspend fun update(schedule: ApplicationSchedule): Boolean {
        val existing = dao.getById(schedule.id) ?: return false
        val entity = toEntity(
            schedule,
            createdAt = existing.createdAt,
            updatedAt = System.currentTimeMillis(),
        )
        return dao.update(entity) > 0
    }

    suspend fun delete(id: Long): Boolean = dao.deleteById(id) > 0

    private fun toModel(entity: MdmScheduleEntity) = ApplicationSchedule(
        id = entity.id,
        packageName = entity.packageName,
        startMinuteOfDay = entity.startMinuteOfDay,
        endMinuteOfDay = entity.endMinuteOfDay,
        daysOfWeek = entity.daysOfWeek.split(',').mapNotNull { it.trim().toIntOrNull() }.toSet(),
        enabled = entity.enabled,
    )

    private fun toEntity(schedule: ApplicationSchedule, createdAt: Long, updatedAt: Long) =
        MdmScheduleEntity(
            id = schedule.id,
            packageName = schedule.packageName,
            startMinuteOfDay = schedule.startMinuteOfDay,
            endMinuteOfDay = schedule.endMinuteOfDay,
            daysOfWeek = schedule.daysOfWeek.sorted().joinToString(","),
            enabled = schedule.enabled,
            createdAt = createdAt,
            updatedAt = updatedAt,
        )
}
