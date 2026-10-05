import { Body, Controller, Post, Res } from "@nestjs/common";
import type { Response } from "express";
import { Public, RawResponse } from "@app/common";
import { EnglishAuthService } from "./english-auth.service";

const TOKEN_COOKIE_MAX_AGE_MS = 60 * 60 * 24 * 30 * 1000;

@Public()
@RawResponse()
@Controller("api/english/auth")
export class EnglishAuthController {
  constructor(private readonly authService: EnglishAuthService) {}

  @Post("login")
  async login(
    @Body() body: { email: string; password: string },
    @Res({ passthrough: true }) res: Response,
  ) {
    const result = await this.authService.login(body.email, body.password);
    res.cookie("token", result.token, {
      httpOnly: true,
      maxAge: TOKEN_COOKIE_MAX_AGE_MS,
      path: "/",
    });
    return result;
  }

  @Post("register")
  async register(
    @Body() body: { email: string; password: string; name?: string },
    @Res({ passthrough: true }) res: Response,
  ) {
    const result = await this.authService.register(
      body.email,
      body.password,
      body.name,
    );
    res.cookie("token", result.token, {
      httpOnly: true,
      maxAge: TOKEN_COOKIE_MAX_AGE_MS,
      path: "/",
    });
    return result;
  }

  @Post("token-exchange")
  async tokenExchange(
    @Body() body: { token: string },
    @Res({ passthrough: true }) res: Response,
  ) {
    const result = await this.authService.nihongoTokenExchange(body.token);
    res.cookie("token", result.token, {
      httpOnly: true,
      maxAge: TOKEN_COOKIE_MAX_AGE_MS,
      path: "/",
    });
    return result;
  }

  // Called from english-web frontend to set cookie on the correct domain
  @Post("set-cookie")
  async setCookie(
    @Body() body: { token: string },
    @Res({ passthrough: true }) res: Response,
  ) {
    // Verify it's a valid English token before setting
    const verified = await this.authService.verifyRequest({
      headers: { authorization: `Bearer ${body.token}` },
      cookies: {},
    } as unknown as import("express").Request);
    if (!verified) throw new Error("Invalid token");

    res.cookie("token", body.token, {
      httpOnly: true,
      maxAge: TOKEN_COOKIE_MAX_AGE_MS,
      path: "/",
    });
    return { ok: true };
  }
}
