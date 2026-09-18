import 'package:hifz_api_client/hifz_api_client.dart';

/// The mobile shell supplies a dio client with auth interceptors; `data` stays
/// agnostic of how the client is built.
typedef ReviewsApiFactory = ReviewsApi Function();

/// Latest client used for outbox flushes.
ReviewsApi defaultReviewsApiFactory(HifzApiClient client) => client.getReviewsApi();
