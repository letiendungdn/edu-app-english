import { Controller, Get, UseGuards } from "@nestjs/common";
import { Public, RawResponse } from "@app/common";
import {
  CurrentEnglishUser,
  type EnglishUserPayload,
} from "../auth/english-current-user.decorator";
import { EnglishAuthGuard } from "../auth/english-auth.guard";
import { EnglishAnalyticsService } from "./english-analytics.service";

@Public()
@RawResponse()
@Controller("api/english/analytics")
export class EnglishAnalyticsController {
  constructor(private readonly analyticsService: EnglishAnalyticsService) {}

  @Get()
  @UseGuards(EnglishAuthGuard)
  getDashboard(@CurrentEnglishUser() user: EnglishUserPayload) {
    return this.analyticsService.getDashboard(user.id);
  }
}
