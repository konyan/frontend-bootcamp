const greet = (name: string): string => `Hello, ${name}!`;

const nums = [1, 2, 3, 4, 5];
const doubled = nums.map((n) => n * 2);

const user = { id: 1, name: "Alice", role: "admin" };
const { name, ...rest } = user;

async function fetchUser(id: number): Promise<{ id: number; name: string }> {
  const response = await fetch(`/api/users/${id}`);
  return response.json();
}

export { greet, doubled, fetchUser };
