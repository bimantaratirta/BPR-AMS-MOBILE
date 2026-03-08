import 'package:bpr_ams/app/data/main/api/api_response_model.dart';
import 'package:bpr_ams/app/data/modules/point_record/point_record_repository.dart';
import 'package:bpr_ams/app/data/modules/point_record/models/point_record_model.dart';

class PointRecordService {
  final PointRecordRepository _repository = PointRecordRepository();

  Future<ApiResponseModel<List<PointRecordModel>>> getPointRecords({Map<String, dynamic>? queryParameters}) async {
    try {
      return await _repository.getPointRecords(queryParameters: queryParameters);
    } catch (e) {
      return ApiResponseModel(error: e.toString());
    }
  }

  Future<ApiResponseModel<PointRecordModel>> getPointRecordById(String id) async {
    try {
      return await _repository.getPointRecordById(id);
    } catch (e) {
      return ApiResponseModel(error: e.toString());
    }
  }
}
