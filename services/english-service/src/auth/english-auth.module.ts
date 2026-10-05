import { Module } from "@nestjs/common";
import { ConfigModule, ConfigService } from "@nestjs/config";
import { JwtModule } from "@nestjs/jwt";
import { EnglishAuthController } from "./english-auth.controller";
import { EnglishAuthService } from "./english-auth.service";
import {
  EnglishAuthGuard,
  EnglishOptionalAuthGuard,
} from "./english-auth.guard";

@Module({
  imports: [
    JwtModule.registerAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (config: ConfigService) => ({
        secret:
          config.get<string>("jwt.secret") ??
          process.env.JWT_SECRET ??
          "fallback-secret",
        signOptions: { expiresIn: "30d" },
      }),
    }),
  ],
  controllers: [EnglishAuthController],
  providers: [EnglishAuthService, EnglishAuthGuard, EnglishOptionalAuthGuard],
  exports: [
    EnglishAuthService,
    EnglishAuthGuard,
    EnglishOptionalAuthGuard,
    JwtModule,
  ],
})
export class EnglishAuthModule {}
