package com.smeinvoice.common;

/** Headers set by the API Gateway after it validates the JWT. */
public final class SecurityHeaders {
    public static final String USER_ID = "X-User-Id";
    public static final String USER_ROLE = "X-User-Role";

    private SecurityHeaders() { }
}
