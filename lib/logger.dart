import 'dart:developer' as dev;
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class LoggerClass{
  static File? _logFile;
  static RandomAccessFile? RemoteAccessFile;

  static Future<void> initLogger() async {
    try{
      Directory directory =  await getApplicationDocumentsDirectory();
      String filePath = "${directory.path}/app_logs.txt";
      dev.log("File_Path: $filePath");
      _logFile = File(filePath);
    }catch(error){
      dev.log("Error_occurred_when_initialising_file: ${error.toString()}");
    }
  }

  static Future<void> saveLog(String log) async {
    try{
      if(_logFile == null){
        await initLogger();
      }
      RandomAccessFile accessFile = await _logFile!.open(mode: FileMode.append);
      String timeStamp = getFormattedDateTimeWithMilliseconds();

      RandomAccessFile lockedFile = await accessFile.lock(FileLock.blockingExclusive);
      RemoteAccessFile = lockedFile;
      if(log == "app_startup"){
       await lockedFile.writeString('\n');
      }
      await lockedFile.writeString("$timeStamp:::>\t\t$log\n");
      await lockedFile.flush();
      // await accessFile.unlock();
      await lockedFile.close();


    }catch(error, stackTrace){
      dev.log("Error_occurred_when_saving_log: ${error.toString()}, $stackTrace");
    }
  }

  static String getFormattedDateTimeWithMilliseconds() {
    DateTime now = DateTime.now();
    DateFormat dateTimeFormat = DateFormat('dd-MM-yyyy HH:mm:ss');
    String formattedDateTime = dateTimeFormat.format(now);
    String milliseconds = now.millisecond.toString().padLeft(3, '0');
    return "$formattedDateTime.$milliseconds";
  }

}