import type { NextApiRequest, NextApiResponse } from "next";
import { stringify } from "querystring";

import { WEBAPP_URL } from "@calcom/lib/constants";

import { encodeOAuthState } from "../../_utils/encodeOAuthState";
import getAppKeysFromSlug from "../../_utils/getAppKeysFromSlug";

const scopes = ["User.Read", "Calendars.Read", "Calendars.ReadWrite", "offline_access"];

let client_id = "4412d288-66aa-478a-8a23-01ee1d6be4ef";

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method === "GET") {
    const appKeys = await getAppKeysFromSlug("office365-calendar");
    if (typeof appKeys.client_id === "string") client_id = appKeys.client_id;
    if (!client_id) return res.status(400).json({ message: "Office 365 client_id missing." });
    const state = encodeOAuthState(req);
    const params = {
      response_type: "code",
      scope: scopes.join(" "),
      client_id,
      redirect_uri: WEBAPP_URL + "/api/integrations/office365calendar/callback",
      state,
    };
    const query = stringify(params);
    const url = `https://login.microsoftonline.com/common/oauth2/v2.0/authorize?${query}`;
    res.status(200).json({ url });
  }
}
