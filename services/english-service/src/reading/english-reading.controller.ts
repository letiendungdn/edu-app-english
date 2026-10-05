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
import { EnglishReadingService } from "./english-reading.service";

@Public()
@RawResponse()
@Controller("api/english/reading")
export class EnglishReadingController {
  constructor(private readonly readingService: EnglishReadingService) {}

  @Get()
  listPassages(@Query("level") level: string | undefined) {
    return this.readingService.listPassages(level);
  }

  @Get(":id/submit")
  getPassage(@Param("id", ParseIntPipe) id: number) {
    return this.readingService.getPassageForSubmit(id);
  }

  @Post(":id/submit")
  @UseGuards(EnglishOptionalAuthGuard)
  submitAnswers(
    @Param("id", ParseIntPipe) id: number,
    @Body() body: { answers: Record<string, string> },
    @Req() req: EnglishAuthRequest,
  ) {
    return this.readingService.submitAnswers(id, body.answers, req.englishUser);
  }
}
