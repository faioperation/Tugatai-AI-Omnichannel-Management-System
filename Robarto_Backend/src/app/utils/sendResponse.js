export const sendResponse = (res, data) => {
  const responseObj = {
    message: data.message,
    success: data.success,
    statusCode: data.statusCode,
    meta: data.meta,
    data: data.data,
  };
  if (data.continueAiFalseCount !== undefined) {
    responseObj.continueAiFalseCount = data.continueAiFalseCount;
  }
  res.status(data.statusCode).json(responseObj);
};