import { Request, Response } from 'express';
declare const app: import("express-serve-static-core").Express;
export declare function stripeWebhookHandler(req: Request, res: Response): Promise<void>;
export default app;
