import {
  Body,
  Controller,
  Get,
  Param,
  ParseIntPipe,
  Post,
  Query,
  Req,
  UseGuards,
} from "@nestjs/common";
import { Public, RawResponse } from "@app/common";
import type { EnglishAuthRequest } from "../auth/english-current-user.decorator";
import { EnglishOptionalAuthGuard } from "../auth/english-auth.guard";
import { EnglishListeningService } from "./english-listening.service";

@Public()
@RawResponse()
@Controller("api/english/listening")
export class EnglishListeningController {
  constructor(private readonly listeningService: EnglishListeningService) {}

  @Get()
  listTracks(@Query("level") level: string | undefined) {
    return this.listeningService.listTracks(level);
  }

  @Get(":id/submit")
  getTrack(@Param("id", ParseIntPipe) id: number) {
    return this.listeningService.getTrackForSubmit(id);
  }

  @Post(":id/submit")
  @UseGuards(EnglishOptionalAuthGuard)
  submitAnswers(
    @Param("id", ParseIntPipe) id: number,
    @Body() body: { answers: Record<string, string> },
    @Req() req: EnglishAuthRequest,
  ) {
    return this.listeningService.submitAnswers(
      id,
      body.answers,
      req.englishUser,
    );
  }
}
