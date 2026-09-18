# hifz_api_client.api.AuthApi

## Load the API package
```dart
import 'package:hifz_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**authControllerLogin**](AuthApi.md#authcontrollerlogin) | **POST** /api/v1/auth/login | 
[**authControllerMe**](AuthApi.md#authcontrollerme) | **GET** /api/v1/auth/me | 
[**authControllerRefresh**](AuthApi.md#authcontrollerrefresh) | **POST** /api/v1/auth/refresh | 
[**authControllerRegister**](AuthApi.md#authcontrollerregister) | **POST** /api/v1/auth/register | 


# **authControllerLogin**
> AuthResponseOutput authControllerLogin(loginRequest)



### Example
```dart
import 'package:hifz_api_client/api.dart';

final api = HifzApiClient().getAuthApi();
final LoginRequest loginRequest = ; // LoginRequest | 

try {
    final response = api.authControllerLogin(loginRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->authControllerLogin: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **loginRequest** | [**LoginRequest**](LoginRequest.md)|  | 

### Return type

[**AuthResponseOutput**](AuthResponseOutput.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authControllerMe**
> AuthUserOutput authControllerMe()



### Example
```dart
import 'package:hifz_api_client/api.dart';

final api = HifzApiClient().getAuthApi();

try {
    final response = api.authControllerMe();
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->authControllerMe: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**AuthUserOutput**](AuthUserOutput.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authControllerRefresh**
> AuthResponseOutput authControllerRefresh(refreshRequest)



### Example
```dart
import 'package:hifz_api_client/api.dart';

final api = HifzApiClient().getAuthApi();
final RefreshRequest refreshRequest = ; // RefreshRequest | 

try {
    final response = api.authControllerRefresh(refreshRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->authControllerRefresh: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **refreshRequest** | [**RefreshRequest**](RefreshRequest.md)|  | 

### Return type

[**AuthResponseOutput**](AuthResponseOutput.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authControllerRegister**
> AuthResponseOutput authControllerRegister(registerRequest)



### Example
```dart
import 'package:hifz_api_client/api.dart';

final api = HifzApiClient().getAuthApi();
final RegisterRequest registerRequest = ; // RegisterRequest | 

try {
    final response = api.authControllerRegister(registerRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->authControllerRegister: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **registerRequest** | [**RegisterRequest**](RegisterRequest.md)|  | 

### Return type

[**AuthResponseOutput**](AuthResponseOutput.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

