# hifz_api_client.api.HealthApi

## Load the API package
```dart
import 'package:hifz_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**healthControllerCheck**](HealthApi.md#healthcontrollercheck) | **GET** /api/v1/health | 


# **healthControllerCheck**
> healthControllerCheck()



### Example
```dart
import 'package:hifz_api_client/api.dart';

final api = HifzApiClient().getHealthApi();

try {
    api.healthControllerCheck();
} on DioException catch (e) {
    print('Exception when calling HealthApi->healthControllerCheck: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

