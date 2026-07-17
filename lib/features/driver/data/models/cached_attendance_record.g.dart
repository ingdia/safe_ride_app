
part of 'cached_attendance_record.dart';

class CachedAttendanceRecordAdapter extends TypeAdapter<CachedAttendanceRecord> {
  @override
  final int typeId = 0;

  @override
  CachedAttendanceRecord read(BinaryReader reader) {
    return CachedAttendanceRecord(
      studentId: reader.readString(),
      studentName: reader.readString(),
      stopName: reader.readString(),
      statusIndex: reader.readInt(),
      recordedAt: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      synced: reader.readBool(),
    );
  }

  @override
  void write(BinaryWriter writer, CachedAttendanceRecord obj) {
    writer.writeString(obj.studentId);
    writer.writeString(obj.studentName);
    writer.writeString(obj.stopName);
    writer.writeInt(obj.statusIndex);
    writer.writeInt(obj.recordedAt.millisecondsSinceEpoch);
    writer.writeBool(obj.synced);
  }
}
