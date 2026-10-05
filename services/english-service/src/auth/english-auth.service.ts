import {
  ConflictException,
  Injectable,
  UnauthorizedException,
} from "@nestjs/common";
import { JwtService } from "@nestjs/jwt";
import * as bcrypt from "bcryptjs";
import * as crypto from "node:crypto";
import type { Request } from "express";
import { Role } from "@edu/prisma-english/client";
import { EnglishPrismaService } from "@app/prisma-english";
import type { EnglishUserPayload } from "./english-current-user.decorator";

export interface EnglishJwtPayload {
  sub: number;
  email: string;
  role: Role;
  aud: "english";
}

@Injectable()
export class EnglishAuthService {
  constructor(
    private readonly prisma: EnglishPrismaService,
    private readonly jwtService: JwtService,
  ) {}

  async login(email: string, password: string) {
    const user = await this.prisma.user.findUnique({ where: { email } });
    if (!user || !(await bcrypt.compare(password, user.passwordHash))) {
      throw new UnauthorizedException("Invalid credentials");
    }

    await this.prisma.user.update({
      where: { id: user.id },
      data: { lastActiveAt: new Date() },
    });

    const token = this.signToken(user);
    return {
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
        role: user.role,
      },
      token,
    };
  }

  async register(email: string, password: string, name?: string) {
    if (!email || !password) {
      throw new ConflictException("Missing fields");
    }

    const existing = await this.prisma.user.findUnique({ where: { email } });
    if (existing) {
      throw new ConflictException("Email already exists");
    }

    const passwordHash = await bcrypt.hash(password, 10);
    const user = await this.prisma.user.create({
      data: { email, passwordHash, name },
    });

    const token = this.signToken(user);
    return {
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
        role: user.role,
      },
      token,
    };
  }

  signToken(user: { id: number; email: string; role: Role }): string {
    return this.jwtService.sign({
      sub: user.id,
      email: user.email,
      role: user.role,
      aud: "english",
    });
  }

  async verifyRequest(req: Request): Promise<EnglishUserPayload | null> {
    const token = this.extractToken(req);
    if (!token) return null;

    try {
      const payload = this.jwtService.verify<EnglishJwtPayload>(token);
      if (payload.aud !== "english") return null;

      return this.prisma.user.findUnique({
        where: { id: payload.sub },
        select: { id: true, email: true, role: true, name: true },
      });
    } catch {
      return null;
    }
  }

  async nihongoTokenExchange(nihongoToken: string) {
    let payload: { sub?: number; email?: string; aud?: string };
    try {
      payload = this.jwtService.verify<{
        sub: number;
        email: string;
        aud?: string;
      }>(nihongoToken);
    } catch {
      throw new UnauthorizedException("Token nihongo không hợp lệ");
    }

    if (payload.aud === "english") {
      throw new UnauthorizedException("Đây đã là English token");
    }

    const email = payload.email;
    if (!email) throw new UnauthorizedException("Token không có email");

    let user = await this.prisma.user.findUnique({ where: { email } });
    if (!user) {
      const randomPwd = await bcrypt.hash(
        crypto.randomBytes(32).toString("hex"),
        10,
      );
      user = await this.prisma.user.create({
        data: { email, passwordHash: randomPwd },
      });
    }

    await this.prisma.user.update({
      where: { id: user.id },
      data: { lastActiveAt: new Date() },
    });

    const token = this.signToken(user);
    return {
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
        role: user.role,
      },
      token,
    };
  }

  private extractToken(req: Request): string | undefined {
    const authHeader = req.headers.authorization;
    if (authHeader?.startsWith("Bearer ")) {
      return authHeader.slice(7);
    }
    const cookies = req.cookies as Record<string, string> | undefined;
    return cookies?.token;
  }
}
