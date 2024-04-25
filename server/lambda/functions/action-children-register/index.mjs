import {
  addCorsHeaders,
  connectToDB,
  generateID,
  TEMP_PARENT_ID,
} from "/opt/nodejs/lib.mjs";
import {
  UNIQUE_VIOLATION,
} from "pg-error-constants";

let db = await connectToDB();

const MAX_ATTEMPTS = 3;
export const handler = async (event) => {
  let attempts = 0;
  let allocated = false;
  let tentativeChildID;
  const parentID = TEMP_PARENT_ID;
  while (attempts < MAX_ATTEMPTS) {
    tentativeChildID = generateID();
    console.log(`attempt ${attempts+1}/${MAX_ATTEMPTS}: trying to allocate ID ${tentativeChildID} to parent with ID ${parentID}`);
    try {
      await db.query(
        "INSERT INTO children (id,parent_id) VALUES ($1,$2)",
        [tentativeChildID, parentID]
      );
    } catch (e) {
      if (e.code === UNIQUE_VIOLATION && e.constraint === "children_pkey") {
        console.error(`attempt ${attempts+1}/${MAX_ATTEMPTS}: failed to allocate ID ${tentativeChildID}`);
        attempts++;
        continue;
      }
      throw e;
    }
    allocated = true;
    break;
  }
  if (!allocated) {
    const code = 500;
    const errResp = {
      statusCode: code,
      body: JSON.stringify({
        errors: [
          {
            resource: event.resource,
            statusCode: code,
            message: "exceeded max number of attempts to allocate random ID to child, try again later"
          }
        ]
      }),
    };
    addCorsHeaders(errResp);
    return errResp;
  }
  const finalChildID = tentativeChildID;
  console.log(`made child row with id ${finalChildID}`);
  const response = {
    statusCode: 200,
    body: JSON.stringify(
      {
        data: {
          id: finalChildID,
        }
      }
    ),
  };
  addCorsHeaders(response);
  return response;
};
