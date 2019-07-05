export const b2b64 = file => {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.readAsDataURL(file);
    reader.onload = () => resolve(reader.result);
    reader.onerror = error => reject(error);
  });
}

export const blob_to_base64 = async file => {
  return await b2b64(file);
}

export default {
  b2b64,
  blob_to_base64
}
