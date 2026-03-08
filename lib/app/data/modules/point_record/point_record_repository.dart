import 'package:bpr_ams/app/common/constant/app_constants.dart';
import 'package:bpr_ams/app/data/main/api/api_params_model.dart';
import 'package:bpr_ams/app/data/main/api/api_response_model.dart';
import 'package:bpr_ams/app/data/modules/point_record/models/point_record_model.dart';
import 'package:bpr_ams/app/network/api_client.dart';

class PointRecordRepository {
  // ── Get all (with optional query params) ────────────────────
  Future<ApiResponseModel<List<PointRecordModel>>> getPointRecords({Map<String, dynamic>? queryParameters}) async {
    return await apiClient.get(
      ApiParams<List<PointRecordModel>>(
        path: AppConstants.pointRecordPathApi,
        queryParameters: queryParameters,
        fromJson: (json) {
          if (json is List) {
            return json.map((e) => PointRecordModel.fromJson(e)).toList();
          }
          return <PointRecordModel>[];
        },
      ),
    );
  }

  // ── Get by ID ───────────────────────────────────────────────
  Future<ApiResponseModel<PointRecordModel>> getPointRecordById(String id) async {
    return await apiClient.get(
      ApiParams<PointRecordModel>(
        path: "${AppConstants.pointRecordPathApi}/$id",
        fromJson: (json) => PointRecordModel.fromJson(json),
      ),
    );
  }
}
