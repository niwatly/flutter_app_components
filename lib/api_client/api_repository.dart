import 'api_client.dart';

abstract class IApiRepository {
  IApiClient get apiClient;
  void close();
}
