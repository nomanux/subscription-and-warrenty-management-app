export interface LocalReceipt {
  uri: string;
}

export async function saveReceiptImageLocally(uri: string): Promise<LocalReceipt> {
  return { uri };
}
