import type { ErrorHandler, NotFoundHandler } from 'hono';

import { HttpError, jsonError } from '../http';

export const handleError: ErrorHandler = (error) => jsonError(error);

export const handleNotFound: NotFoundHandler = () =>
  jsonError(new HttpError('NOT_FOUND', 'Route was not found', 404));
