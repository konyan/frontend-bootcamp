interface User {
  name: string
  email?: string
}

const greet = async (user: User): Promise<string> => {
  const name = user?.name ?? 'stranger'
  return `Hello, ${name}!`
}

const formatUsers = (users: User[]): string[] =>
  users.map(u => u.name)

export { greet, formatUsers }
