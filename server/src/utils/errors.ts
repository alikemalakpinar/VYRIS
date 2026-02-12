/**
 * Typed application errors with HTTP status codes.
 * Every endpoint must return explicit error codes.
 */

export class AppError extends Error {
  constructor(
    public readonly statusCode: number,
    public readonly code: string,
    message: string,
    public readonly retryable: boolean = false,
  ) {
    super(message);
    this.name = 'AppError';
  }
}

export function soldOut(): AppError {
  return new AppError(410, 'SOLD_OUT', 'No allocations remaining for this drop');
}

export function receiptUsed(membershipId: string): AppError {
  const err = new AppError(
    409,
    'RECEIPT_USED',
    'This receipt has already been fulfilled',
  );
  (err as AppError & { membershipId: string }).membershipId = membershipId;
  return err;
}

export function invalidReceipt(detail: string): AppError {
  return new AppError(422, 'INVALID_RECEIPT', `Invalid receipt: ${detail}`);
}

export function unauthorized(detail: string = 'Unauthorized'): AppError {
  return new AppError(401, 'UNAUTHORIZED', detail);
}

export function retryable(detail: string): AppError {
  return new AppError(500, 'RETRYABLE', detail, true);
}

export function notFound(detail: string): AppError {
  return new AppError(404, 'NOT_FOUND', detail);
}

export function conflict(detail: string): AppError {
  return new AppError(409, 'CONFLICT', detail);
}

export function expired(detail: string): AppError {
  return new AppError(410, 'EXPIRED', detail);
}
