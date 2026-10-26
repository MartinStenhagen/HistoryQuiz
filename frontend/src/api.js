export async function api(path, { method = 'GET', body, accountId } = {}) {
  const isWrite = !['GET', 'HEAD'].includes(method)

  const options = {
    method,
    credentials: 'same-origin',
    headers: {
      ...(isWrite
        ? {
            'Content-Type': 'application/json',
            'X-HistoryQuiz-Request': '1',
          }
        : {}),
      ...(accountId != null ? { 'X-HistoryQuiz-Account': String(accountId) } : {}),
    },
  }
  if (isWrite) options.body = JSON.stringify(body ?? {})
  const response = await fetch(path, options)

  const text = response.status === 204 ? '' : await response.text()
  let data
  try {
    data = text ? JSON.parse(text) : null
  } catch {
    throw Object.assign(new Error('Servern gav ett ogiltigt svar. Försök igen.'), {
      status: response.status,
    })
  }

  if (!response.ok) {
    throw Object.assign(new Error(data?.error ?? 'Anropet misslyckades.'), {
      status: response.status,
      code: data?.code,
    })
  }

  return data
}
