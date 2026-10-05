import { Module } from "@nestjs/common";
import { EnglishAuthModule } from "../auth/english-auth.module";
import { EnglishAnalyticsController } from "./english-analytics.controller";
import { EnglishAnalyticsService } from "./english-analytics.service";

@Module({
  imports: [EnglishAuthModule],
  controllers: [EnglishAnalyticsController],
  providers: [EnglishAnalyticsService],
})
export class EnglishAnalyticsModule {}
