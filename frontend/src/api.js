export async function api(path, { method = 'GET', body } = {}) {
  const isWrite = !['GET', 'HEAD'].includes(method)

  const response = await fetch(path, {
    method,
    credentials: 'same-origin',
    headers: isWrite
      ? {
          'Content-Type': 'application/json',
          'X-HistoryQuiz-Request': '1',
        }
      : {},
    body: isWrite ? JSON.stringify(body ?? {}) : undefined,
  })

  const data = response.status === 204
    ? null
    : await response.json()

  if (!response.ok) {
    throw Object.assign(
      new Error(data?.error ?? 'Anropet misslyckades.'),
      { status: response.status },
    )
  }

  return data
}
