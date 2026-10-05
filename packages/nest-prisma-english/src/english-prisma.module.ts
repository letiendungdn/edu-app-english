import { Global, Module } from "@nestjs/common";
import { EnglishPrismaService } from "./english-prisma.service";

@Global()
@Module({
  providers: [EnglishPrismaService],
  exports: [EnglishPrismaService],
})
export class EnglishPrismaModule {}
