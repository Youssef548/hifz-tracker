# hifz_api_client.api.ReviewsApi

## Load the API package
```dart
import 'package:hifz_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**reviewsControllerCreate**](ReviewsApi.md#reviewscontrollercreate) | **POST** /api/v1/reviews | 
[**reviewsControllerList**](ReviewsApi.md#reviewscontrollerlist) | **GET** /api/v1/reviews | 


# **reviewsControllerCreate**
> ReviewDto reviewsControllerCreate(body)



### Example
```dart
import 'package:hifz_api_client/api.dart';

final api = HifzApiClient().getReviewsApi();
final CreateReviewRequest body = ; // CreateReviewRequest | 

try {
    final response = api.reviewsControllerCreate(body);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ReviewsApi->reviewsControllerCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **body** | **CreateReviewRequest**|  | 

### Return type

[**ReviewDto**](ReviewDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **reviewsControllerList**
> ReviewListResponseOutput reviewsControllerList(studentId)



### Example
```dart
import 'package:hifz_api_client/api.dart';

final api = HifzApiClient().getReviewsApi();
final String studentId = studentId_example; // String | 

try {
    final response = api.reviewsControllerList(studentId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ReviewsApi->reviewsControllerList: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **studentId** | **String**|  | [optional] 

### Return type

[**ReviewListResponseOutput**](ReviewListResponseOutput.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

